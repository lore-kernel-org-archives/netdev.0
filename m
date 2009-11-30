From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 23:26:55 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911302325500.9826@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi> <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba>
 <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi> <20091130222417.77ce13a4@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-1607658785-1259616415=:9826"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38777 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbZK3V0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 16:26:49 -0500
In-Reply-To: <20091130222417.77ce13a4@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1607658785-1259616415=:9826
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Mon, 30 Nov 2009, Frederic Leroy wrote:

> Le Mon, 30 Nov 2009 22:18:22 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Mon, 30 Nov 2009, Frederic Leroy wrote:
> > 
> > > Le Sat, 28 Nov 2009 13:31:14 +0200 (EET),
> > > "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> > point out to yet another problem, however, I'm not sure what I can
> > atm trust in the logs. ...Timestamps would probably help me a bit
> > (I've changed also sleep to do 0.01 granularity):
> 
> I made 2 other traces with 0.01 granularity, but it works normally. I
> suppose there are less interference in the evening.
> 
> The .4 is a bad trace where I forgot to put timestamp. And when I
> realized it was copying successfully, I stopped it before it tooks too
> much space.
> 
> It can be interesting because the stream had a little "pause".
> 
> The .5 is the trace of a successfull copy. I limited packet capture size
> to 96 bytes. It has stalled once in the middle.

Could you compress such big ones. ...I only have 1Mbps downlink here :-).

-- 
 i.
---696230645-1607658785-1259616415=:9826--
