From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v4 1/2] expose stack entry function
Date: Thu, 28 Sep 2017 16:11:54 +0200
Message-ID: <553f7dad-3bb7-ed42-c78d-e54592f87c81@6wind.com>
References: <cover.1506590878.git.amine.kherbouche@6wind.com>
 <d34f8440be3e1d735c694c6899c5a8b14e9a70ea.1506590878.git.amine.kherbouche@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: equinox@diac24.net
To: Amine Kherbouche <amine.kherbouche@6wind.com>,
        netdev@vger.kernel.org, xeb@mail.ru, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:45348 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752608AbdI1OL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 10:11:59 -0400
Received: by mail-wm0-f45.google.com with SMTP id q124so2612027wmb.0
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 07:11:59 -0700 (PDT)
In-Reply-To: <d34f8440be3e1d735c694c6899c5a8b14e9a70ea.1506590878.git.amine.kherbouche@6wind.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/09/2017 à 11:34, Amine Kherbouche a écrit :
> Exporting mpls_forward() function to be able to be called from elsewhere
> such as MPLSoverGRE in the next commit.

I'm nitpicking, but the commit title is too generic. What about something like
'mpls: export mpls_forward()'?

When parsing history, the user knows precisely what is done in the commit
without openning it.


Regards,
Nicolas
