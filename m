From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Bug handling devices with weird names
Date: Fri, 9 Jul 2010 12:04:21 +0200
Message-ID: <AANLkTim3IpnHn8ZedpYAphlA1ZdhzizuJo-azmPtd-kd@mail.gmail.com>
References: <AANLkTinBvzfdiAldJkXfH_vOkCv_cK7hBhjmH1l2vHTd@mail.gmail.com>
	<20100708102747.66d0ad78@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64764 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940Ab0GIKEW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 06:04:22 -0400
Received: by fxm14 with SMTP id 14so928740fxm.19
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 03:04:21 -0700 (PDT)
In-Reply-To: <20100708102747.66d0ad78@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 8, 2010 at 19:27, Stephen Hemminger <shemminger@vyatta.com>=
 wrote:
> Colons are used for the old IP aliasing. IP aliasing was an older way=
 of handling
> multiple addresses per interface, and is not necessary anymore. The s=
yntax is
> retained for legacy compatibility.

I know, but there is some code that is not accepting any valid name.
So i am able to create the device but then I cannot do some stuff. So
that's why I think this is a bug.


--=20
Mart=EDn Ferrari
