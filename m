From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 09 Jan 2007 07:38:28 -0600
Message-ID: <1168349908.4628.3.camel@stevo-desktop>
References: <20061220124125.6286.17148.stgit@localhost.localdomain>
	 <45918CA4.3020601@garzik.org> <45A36C22.6010009@chelsio.com>
	 <45A36E59.30500@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general <openib-general@openib.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932076AbXAINia@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <45A36E59.30500@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland,

The T3 Ethernet driver is queued for inclusion into Jeff's tree.  

How do you want to merge in the RDMA driver?  I can give you a single
monolithic patch if you want.  

We also need to decide on the ib_req_notify_cq() issue.  


Steve.



On Tue, 2007-01-09 at 05:28 -0500, Jeff Garzik wrote:
> Divy Le Ray wrote:
> > Jeff Garzik wrote:
> >> Divy Le Ray wrote:
> >>> From: Divy Le Ray <divy@chelsio.com>
> >>>
> >>> This patch implements the main header files of
> >>> the Chelsio T3 network driver.
> >>>
> >>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> >>
> >> Once you think it's ready, email me a URL to a single patch that adds 
> >> the driver to the latest linux-2.6.git kernel.  Include in the email a 
> >> description of the driver and signed-off-by line, which will get 
> >> directly included in the git changelog.
> >>
> >> Adding new drivers is a bit special, because we want to merge it as a 
> >> single changeset, but that would create a patch too large to review on 
> >> the common kernel mailing lists.
> > Jeff,
> > 
> > You can grab the monolithic patch at this URL:
> > http://service.chelsio.com/kernel.org/cxgb3.patch.bz2
> 
> this is in my queue, thanks.  Sorry I didn't indicate that earlier.
> 
> 	Jeff
> 
> 
> 
