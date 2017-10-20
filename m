From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 1/2] net: dsa: lan9303: Add port_fast_age and port_fdb_dump methods
Date: Fri, 20 Oct 2017 09:57:04 -0400
Message-ID: <87inf92a8f.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171020101910.2245-1-privat@egil-hjelmeland.no> <20171020101910.2245-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020101910.2245-2-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Add DSA method port_fast_age as a step to STP support.
>
> Add low level functions for accessing the lan9303 ALR (Address Logic
> Resolution).
>
> Added DSA method port_fdb_dump
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
