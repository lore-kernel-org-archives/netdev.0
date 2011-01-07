From: Chin Shi Hong <cshong87@gmail.com>
Subject: Re: Use ioctl() to list all network interfaces.
Date: Fri, 7 Jan 2011 13:40:47 +0800
Message-ID: <AANLkTiknDefNjACnu9jBpa4JX4h3V2GUgQtWChnv3FGa@mail.gmail.com>
References: <AANLkTi=Xb4TuKcCd-DgN5ZnYzRHV1RjDScyjRkqyb4P+@mail.gmail.com>
	<201101061811.06847.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:62355 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633Ab1AGFku convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 00:40:50 -0500
Received: by ewy5 with SMTP id 5so7684220ewy.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 21:40:48 -0800 (PST)
In-Reply-To: <201101061811.06847.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/7 R=E9mi Denis-Courmont <remi@remlab.net>:
> Le jeudi 6 janvier 2011 17:33:39 Chin Shi Hong, vous avez =E9crit :
>> My application's role is to display all network interfaces, includin=
g
>> the network interface which are down.
>
> You should use if_nameindex() then.
>
> --
> R=E9mi Denis-Courmont
> http://www.remlab.net/
> http://fi.linkedin.com/in/remidenis
>

Thank you. if_nameindex() really help me.

Regards,
