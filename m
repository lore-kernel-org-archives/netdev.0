From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 07/10] vxlan: port module param should be ushort
Date: Wed, 05 Jun 2013 17:35:36 +0400
Message-ID: <51AF3EA8.4070607@cogentembedded.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org> <1370406254-6341-7-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:59545 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601Ab3FENfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 09:35:38 -0400
Received: by mail-la0-f43.google.com with SMTP id gw10so1426986lab.2
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 06:35:37 -0700 (PDT)
In-Reply-To: <1370406254-6341-7-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-06-2013 8:24, Stephen Hemminger wrote:

> UDP ports's are limited to 16 bits.

    s/ports's/ports/. Maybe a committer can fix.

> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

WBR, Sergei
