From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Tue, 4 May 2010 17:05:31 -0700
Message-ID: <20100504170531.1e7122da@nehalam>
References: <20100504230225.GP8323@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pv-drivers@vmware.com,
	sbhatewara@vmware.com
To: Pankaj Thakkar <pthakkar@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53764 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932379Ab0EEAFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 May 2010 20:05:33 -0400
In-Reply-To: <20100504230225.GP8323@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 May 2010 16:02:25 -0700
Pankaj Thakkar <pthakkar@vmware.com> wrote:

> Device passthrough technology allows a guest to bypass the hypervisor and drive
> the underlying physical device. VMware has been exploring various ways to
> deliver this technology to users in a manner which is easy to adopt. In this
> process we have prepared an architecture along with Intel - NPA (Network Plugin
> Architecture). NPA allows the guest to use the virtualized NIC vmxnet3 to
> passthrough to a number of physical NICs which support it. The document below
> provides an overview of NPA.
> 
> We intend to upgrade the upstreamed vmxnet3 driver to implement NPA so that
> Linux users can exploit the benefits provided by passthrough devices in a
> seamless manner while retaining the benefits of virtualization. The document
> below tries to answer most of the questions which we anticipated. Please let us
> know your comments and queries.
> 
> Thank you.
> 
> Signed-off-by: Pankaj Thakkar <pthakkar@vmware.com>


Code please. Also, it has to work for all architectures not just VMware and
Intel.
