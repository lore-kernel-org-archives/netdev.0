From: Graham Gower <graham.gower@gmail.com>
Subject: Re: skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI motherboard.
Date: Mon, 08 Oct 2012 16:03:31 +1030
Message-ID: <507265AB.5050107@gmail.com>
References: <50711961.1010101@gmail.com> <50714C45.3080103@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35112 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab2JHFdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 01:33:35 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so3609057pad.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 22:33:35 -0700 (PDT)
In-Reply-To: <50714C45.3080103@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2012 08:02 PM, Jan Ceuleers wrote:
> On 10/07/2012 07:55 AM, Graham Gower wrote:
>> Signed-off-by: Graham Gower <graham.gower@gmail.com>
>>
>> --- skge.c.bak    2012-10-07 13:00:56.000000000 +1030
>> +++ skge.c    2012-10-07 13:26:03.000000000 +1030
>> @@ -4143,6 +4143,13 @@
>
> Graham,
>
> Your patch should include the path to the file being patched relative to
> the base directory. So in this case something like
>
> --- a/drivers/net/ethernet/marvell/skge.c ...
> +++ b/drivers/net/ethernet/marvell/skge.c ...
>
> HTH, Jan
>

Thanks, I should know this stuff. Just an oversight because I was
too lazy to clone a repository and diffed against the single file.

-Graham
