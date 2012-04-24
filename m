From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH v2] smsc95xx: mark link down on startup and let PHY
 interrupt deal with carrier changes
Date: Tue, 24 Apr 2012 16:45:57 +0100
Message-ID: <CAKh2mn4JLm8f036d7vNimLdA2wCP+Db7xhgUgfsg760yhs3Yjw@mail.gmail.com>
References: <1335189920-31062-1-git-send-email-paolo.pisati@canonical.com>
	<20120423194339.GS5277@charybde.local>
	<20120424.004240.51699724664176823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fillods@users.sf.net, paolo.pisati@canonical.com,
	steve.glendinning@shawell.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59830 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288Ab2DXPp6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 11:45:58 -0400
Received: by pbbro12 with SMTP id ro12so248283pbb.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 08:45:57 -0700 (PDT)
In-Reply-To: <20120424.004240.51699724664176823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On 24 April 2012 05:42, David Miller <davem@davemloft.net> wrote:
>>> v2: added mantainer to the list of recipient
>>
>> His e-mail address has changed, but somehow it has not been updated =
yet
>> in MAINTAINERS directory: =A0steve.glendinning () shawell.net
>
> Steve, please send a maintainers etc. update and please provide
> feedback on this link status fix.

I submitted an update to MAINTAINERS last week, I don't think it's
been picked up yet.

Thanks for the patch Paulo, I'd like to test this out.  I'll get back
to you in a few days.

--=20
Steve Glendinning
