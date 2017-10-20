From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 2/2] net: dsa: lan9303: Add fdb/mdb manipulation
Date: Fri, 20 Oct 2017 09:57:30 -0400
Message-ID: <87fuad2a7p.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171020101910.2245-1-privat@egil-hjelmeland.no> <20171020101910.2245-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020101910.2245-3-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Add functions for managing the lan9303 ALR (Address Logic
> Resolution).
>
> Implement DSA methods: port_fdb_add, port_fdb_del, port_mdb_prepare,
> port_mdb_add and port_mdb_del.
>
> Since the lan9303 do not offer reading specific ALR entry, the driver
> caches all static entries - in a flat table.
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
