From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH 0/4] PCI error handler const
Date: Fri, 7 Sep 2012 15:42:03 -0700
Message-ID: <CAErSpo6T=vQnP2u6KP0+sDvT5=iQs1UFjpOLub+9y=B2k_MRgQ@mail.gmail.com>
References: <20120907163313.614852012@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linas Vepstas <linasvepstas@gmail.com>, linux-pci@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20120907163313.614852012@vyatta.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 7, 2012 at 9:33 AM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> This is a trivial patch to make PCI error handler function
> tables const. Split into pieces so that core changes are first.

I put all four of these on this branch:

http://git.kernel.org/?p=linux/kernel/git/helgaas/pci.git;a=shortlog;h=refs/heads/pci/stephen-const

If the netdev and scsi folks approve, I can handle them all through my PCI tree.

Bjorn
