From: "Tayar, Tomer" <Tomer.Tayar@cavium.com>
Subject: RE: [PATCH] qed: Delete redundant check on dcb_app priority
Date: Mon, 9 Oct 2017 01:38:17 +0000
Message-ID: <BN3PR0701MB15916FFAC4DADD92C02F784880740@BN3PR0701MB1591.namprd07.prod.outlook.com>
References: <1507502807-19767-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Christos Gkekas <chris.gekas@gmail.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507502807-19767-1-git-send-email-chris.gekas@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> dcb_app priority is unsigned thus checking whether it is less than zero
> is redundant.
>=20
> Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>

Thanks

Acked-By: Tomer Tayar <Tomer.Tayar@cavium.com>
