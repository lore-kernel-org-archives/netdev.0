From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [PATCH 2.6] pci.ids for e1000
Date: Fri, 12 Sep 2003 11:40:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F035@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> How motivated are you?  ;-)
> 
> The general idea is to keep 2.4, 2.6, and pciids.sf.net in sync.
> 
> Could you be talked into comparing 2.4, 2.6, and pciids.sf.net, and 
> creating patches for 2.4 and 2.6 that add missing ids?  ;-)  Martin 
> Mares (pciids.sf.net maintainer) did a big sync-up less than 
> 12 months 
> ago, so the job shouldn't be as big as it sounds.
> 
> If not, no big deal.  Just say "no" and I'll apply the patch below, 
> instead of waiting for the larger patches...

Now that I've dug into this a little more, go ahead and drop my patch
for e1000 IDs.  Bypassing the flow from pciids.sf.net is just going to
cause more problems.  Pciids.sf.net has been updated with these IDs, so
it's just a matter of getting them approved and having Martin push out a
sync for 2.4 and 2.6.  I'll add my request to Martin...

-scott
