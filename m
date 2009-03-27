From: Len Brown <lenb@kernel.org>
Subject: Re: Network Device Naming mechanism and policy
Date: Fri, 27 Mar 2009 12:06:44 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0903271203140.26419@localhost.localdomain>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
 <20090324.155756.214460004.davem@davemloft.net>
 <20090326163955.GA22398@auslistsprd01.us.dell.com>
 <1238098611.3254.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-reply-to: <1238098611.3254.8.camel@localhost.localdomain>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > > So, please, put mapping tables into the ACPI or similar

ACPI added _PLD (Physical Device Location) back in 3.0, ISTR.
However, searching my archives, I have yet to see a single instance
of its use in the field.

ACPI also supplies the slot number stuff, which is exported via 
the existing pci_slot driver.

cheers,
Len Brown, Intel Open Source Technology Center
