From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Mon, 9 Nov 2009 19:06:52 +0800
Message-ID: <412e6f7f0911090306m74d3242cpfa63dc4f697807c9@mail.gmail.com>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:38953 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbZKILGr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 06:06:47 -0500
Received: by pwi3 with SMTP id 3so551818pwi.21
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 03:06:52 -0800 (PST)
In-Reply-To: <1257764086.6246.1.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 9, 2009 at 6:54 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2009-11-09 at 16:31 +0800, Changli Gao wrote:
>
>> code cleanup! :)
>
> I dont really see it as a cleanup to be honest. The code
> is not less ugly even after the change;->
>

Maybe I should remove goto, I'll try later.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
