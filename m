From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vxlan: Accept user specified MTU value when create new
 vxlan link
Date: Mon, 30 May 2016 20:27:48 -0700
Message-ID: <CAM_iQpWbEFetqtn8f_eZjvyRdmTEcHPF4Fs-ZRgeNd0HykjUAQ@mail.gmail.com>
References: <1464317351-22316-1-git-send-email-oc@yunify.com>
 <CAM_iQpULCyju9vor74ygcv5FcqFeoq9KthRuCYfo4=tF0ieHrg@mail.gmail.com> <5749B7B4.60600@yunify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: oc <oc@yunify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33360 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161420AbcEaD2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 23:28:08 -0400
Received: by mail-yw0-f196.google.com with SMTP id y6so17138585ywe.0
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 20:28:08 -0700 (PDT)
In-Reply-To: <5749B7B4.60600@yunify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 28, 2016 at 8:22 AM, oc <oc@yunify.com> wrote:
> 1. vxlan_dev_configure function check conf->mtu to determine if it need to
> change value of dev->mtu.
> The logical looks better to get conf->mtu from IFLA_MTU directly.

Fair enough,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
