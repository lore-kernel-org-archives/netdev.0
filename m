From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] anycast support for IPv6, updated to 2.5.44
Date: Wed, 19 Mar 2003 16:31:05 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030319.163105.44963500.davem@redhat.com>
References: <OFC909BFEE.F581E26E-ON88256C60.0072A662@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OFC909BFEE.F581E26E-ON88256C60.0072A662@boulder.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "David Stevens" <dlstevens@us.ibm.com>
   Date: Mon, 28 Oct 2002 14:06:00 -0700
   
   Below is a patch to add anycast support for IPv6. It's the same patch as
   I've posted previously, but updated with comments from Chris Hellwig and
   for kernel version 2.5.44.

I'm going to apply this, with the small change that dev_getany() is
renamed to dev_get_by_flags() which more accurately describes
what the routine does.

Thanks David.
