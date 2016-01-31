From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net] r8169 Remove duplicate command which set RxVlan and
 RxChksum bits.
Date: Sun, 31 Jan 2016 20:17:26 +0300
Message-ID: <56AE41A6.5060706@cogentembedded.com>
References: <1454254388-15523-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <asd@marian1000.go.ro>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34779 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757309AbcAaRR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 12:17:29 -0500
Received: by mail-lb0-f182.google.com with SMTP id cl12so63295774lbc.1
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 09:17:29 -0800 (PST)
In-Reply-To: <1454254388-15523-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/31/2016 06:33 PM, Corcodel Marian wrote:

>   These bits is already set on set geatures stage.

    Features.

> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
[...]

MBR, Sergei
