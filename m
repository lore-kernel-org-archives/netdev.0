From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: make dsa_switch_ops const
Date: Wed, 09 Aug 2017 10:32:02 -0400
Message-ID: <87mv78hkwt.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1502255055-24751-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502255055-24751-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> writes:

> Make these structures const as they are only stored in the ops field of
> a dsa_switch structure, which is const.
> Done using Coccinelle.
>
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
