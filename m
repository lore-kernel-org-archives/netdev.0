From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Subject: RE: vxge: Update driver_config->vpath_per_dev for each function in probe.
Date: Mon, 5 Oct 2009 05:36:19 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705C1618E@nekter>
References: <Pine.GSO.4.10.10910050506150.2346-100000@guinness> <20091005.023219.45309053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:8839 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758759AbZJEJhS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:37:18 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20091005.023219.45309053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore this patch.

I submitted this patch without patch number. I again resubmitted it with
patch number.


-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Monday, October 05, 2009 3:02 PM
To: Sreenivasa Honnur
Cc: netdev@vger.kernel.org; support
Subject: Re: vxge: Update driver_config->vpath_per_dev for each function
in probe.

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 5 Oct 2009 05:06:56 -0400 (EDT)

> - Update driver_config->vpath_per_dev for each function in probe.
> 
> - vpath_per_device specifies number of vpaths supported for each
function/device. The
>   current code was updating vpath_per_device only for physical device,
however this has
>   to be updated for each function also in case of a MF(Multi function)
device.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

You keep posting this patch twice.

Once without the proper "[PATCH 2/9]" indication in the subject heading,
and once with it there.

Please sort out your patch set, there is something wrong with what
you're submitting for this.
