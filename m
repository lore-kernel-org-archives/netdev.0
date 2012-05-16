From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Wed, 16 May 2012 17:10:38 +0400
Message-ID: <4FB3A74E.4060303@mvista.com>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgq516@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:47611 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966185Ab2EPNLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 09:11:07 -0400
Received: by lahd3 with SMTP id d3so481077lah.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 06:11:05 -0700 (PDT)
In-Reply-To: <1337155302-26244-1-git-send-email-jgq516@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 16-05-2012 12:01, jgq516@gmail.com wrote:

> From: Xiao Jiang<jgq516@gmail.com>

> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet devices

    Please also specify that commit's summary in parens.

> which possibly use "usb%d" names, add this flag to make sure pandaboard
> can mount nfs with smsc95xx NIC.

> Signed-off-by: Xiao Jiang<jgq516@gmail.com>

WBR, Sergei
