From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [BUG] in skge.c on 2.6.18-rc5
Date: Wed, 30 Aug 2006 19:21:20 +0200
Message-ID: <7d01f9f00608301021v5d02b18dg8b0d993ee3dd1977@mail.gmail.com>
References: <7d01f9f00608300830j74871672o31b9ce126ee8c07d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.204]:36108 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751140AbWH3RVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 13:21:20 -0400
Received: by nz-out-0102.google.com with SMTP id n1so163873nzf
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 10:21:20 -0700 (PDT)
To: shemminger@osdl.org
In-Reply-To: <7d01f9f00608300830j74871672o31b9ce126ee8c07d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replying to myself as I've been pointed at Stephen's reply (please CC
me, i'm not subscribed):

I'm bringing the interface up with 'dhclient eth0', and yes it's using autoneg.

HTH

T_Bone

On 8/30/06, Thibaut VARENE <T-Bone@parisc-linux.org> wrote:
> Hi,
>
> The following commit:
>
> commit 239e44e1f05e2163ee066c07a753f9fb445979b2
> Author: Edgar E. Iglesias <edgar.iglesias@axis.com>
> Date:   Mon Aug 14 23:00:24 2006 -0700

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
