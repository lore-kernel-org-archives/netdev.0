From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Mon, 27 Jul 2015 22:07:11 +0200
Message-ID: <55B68F6F.9020607@6wind.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com> <55B24B9B.4080001@cumulusnetworks.com> <55B24C85.2010502@6wind.com> <55B25798.2040706@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35345 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbbG0UHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 16:07:15 -0400
Received: by wibxm9 with SMTP id xm9so128004278wib.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 13:07:13 -0700 (PDT)
In-Reply-To: <55B25798.2040706@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2015 17:19, David Ahern a =E9crit :
> In this case you are knowingly dropping packets. Would be nice to hav=
e a counter
> showing that.
Ok.
