From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Fri, 14 Jul 2006 22:03:30 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607142202380.19821@d.namei>
References: <20060714185739.780700000@flek.zko.hp.com>
 <20060714185915.270209000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>, sds@epoch.ncsc.mil,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:26551 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1945968AbWGOCDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 22:03:33 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20060714185915.270209000@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006, paul.moore@hp.com wrote:


> +/**
> + * cipso_v4_bitmap_walk - Walk a bitmap looking for a bit

> + * cipso_v4_bitmap_setbit - Sets a single bit in a bitmap


Can you use lib/bitmap.c instead?


-- 
James Morris
<jmorris@namei.org>
