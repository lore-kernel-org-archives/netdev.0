From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Fri, 21 Dec 2007 16:10:40 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712211609540.7301@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie> <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
 <20071221.031400.194877955.davem@davemloft.net> <20071221133106.GA7995@nuim.ie>
 <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696243703-1085451526-1198246049=:7301"
Cc: Netdev <netdev@vger.kernel.org>
To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45599 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbXLUOKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:10:42 -0500
In-Reply-To: <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0712211609541.7301@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1085451526-1198246049=:7301
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712211609542.7301@kivilampi-30.cs.helsinki.fi>

On Fri, 21 Dec 2007, Ilpo Järvinen wrote:

> On Fri, 21 Dec 2007, Gavin McCullagh wrote:
> 
> > I'm just checking through the existing CA modules.  I don't see the rtt
> > used for RTO anywhere.  This is what I gather they're each using rtt for.
> 
> I meant more timeout like fashion (e.g., to "timeout" some internal 
> phase but I don't find that too likely)...

I meant didn't, no need to recheck them due to that... :-)

-- 
 i.
---696243703-1085451526-1198246049=:7301--
