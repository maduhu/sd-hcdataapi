//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace HarvestChoiceApi.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class collection_group
    {
        public int ID { get; set; }
        public string group { get; set; }
        public string collection_code { get; set; }
    
        public virtual collection collection { get; set; }
    }
}