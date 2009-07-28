From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [question] bridged tunnel
Date: Tue, 28 Jul 2009 11:11:15 +0300
Message-ID: <200907281111.16433.remi.denis-courmont@nokia.com>
References: <20090728075928.GB3633@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:50711 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbZG1ILi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:11:38 -0400
In-Reply-To: <20090728075928.GB3633@psychotron.englab.brq.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 July 2009 10:59:29 ext Jiri Pirko wrote:
> Hello all.
>
> Imagine following net scheme:
>
> LAN1 --- ROUTER A --- ROUTER B --- LAN2
>
> I would like to have LAN1 and LAN2 bridged together.

Then just put both interfaces to LAN1 and LAN2 in the same bridge... Wh=
y do=20
you want to bring TAP here?!

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

