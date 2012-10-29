From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: remove useless test in
 dev_forward_change()
Date: Mon, 29 Oct 2012 10:31:31 +0100
Message-ID: <1351503091.7394.316.camel@edumazet-glaptop>
References: <20121029015709.GA18567@localhost>
	 <1351502649-3876-1-git-send-email-nicolas.dichtel@6wind.com>
	 <k6lhsd$jui$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47744 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab2J2Jbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 05:31:36 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1845336bkc.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 02:31:35 -0700 (PDT)
In-Reply-To: <k6lhsd$jui$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 09:22 +0000, Cong Wang wrote:
> On Mon, 29 Oct 2012 at 09:24 GMT, Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> > idev->dev cannot be NULL.
> >
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> I sent a same patch before you:
> 
> http://marc.info/?l=linux-netdev&m=135148225303417&w=2
> 
> :)

Yes, and it got proper attribution to Fengguang Wu

Thanks
