From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Constantly varying download rate with a complex xen networking
 setup, why?
Date: Wed, 17 Jun 2009 17:02:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906171659380.31880@melkinkari.cs.Helsinki.FI>
References: <20090615075313.GA22819@rivendell>
 <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
 <20090615160254.GA8550@rivendell> <Pine.LNX.4.64.0906151910220.16408@melkinkari.cs.Helsinki.FI>
 <20090617130050.GA18586@rivendell>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243445-285537263-1245247328=:31880"
Cc: Netdev <netdev@vger.kernel.org>
To: Raphael Hertzog <raphael@ouaza.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38927 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbZFQOCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 10:02:42 -0400
In-Reply-To: <20090617130050.GA18586@rivendell>
Content-ID: <Pine.LNX.4.64.0906171702140.31880@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-285537263-1245247328=:31880
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0906171702141.31880@melkinkari.cs.Helsinki.FI>

On Wed, 17 Jun 2009, Raphael Hertzog wrote:

> Le lundi 15 juin 2009, Ilpo Järvinen a écrit :
> > Maybe the proxy interferes there somehow... I don't know enough about the
> > details to say but I suppose the proxy at least breaks your tcp connection 
> > to two parts.
> 
> Indeed. Is there some processing done in a simple linux bridge where the
> reapperance of the same TCP packet that has been created and sent on another
> local interface could create problem?

I thought out had a http proxy in between? I suppose it is certainly doing 
more than bridging. Anyway, I'll be week away, so no quick responses are 
to be expected from my part after this mail.


-- 
 i.
---696243445-285537263-1245247328=:31880--
