From: Florian Fainelli <f.fainelli@gmail.com>
Subject: RE: [RESEND PATCH 2/6] staging: fsl-dpaa2/ethsw: Add Freescale DPAA2 Ethernet Switch driver
Date: Fri, 29 Sep 2017 09:11:18 -0700
Message-ID: <A4C4732A-CC1F-4707-89F8-E7284F022DB0@gmail.com>
References: <1505825158-8192-1-git-send-email-razvan.stefanescu@nxp.com> <1505825158-8192-3-git-send-email-razvan.stefanescu@nxp.com> <DB5PR04MB12400025DF190790B4792B50EA7E0@DB5PR04MB1240.eurprd04.prod.outlook.com> <AM3PR04MB0743F62497ED0CB445F51524E67E0@AM3PR04MB0743.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "agraf@suse.de" <agraf@suse.de>, "arnd@arndb.de" <arnd@arndb.de>,
        Alexandru Marginean <alexandru.marginean@nxp.com>,
        Ruxandra Ioana Radulescu <ruxandra.radulescu@nxp.com>,
        Laurentiu Tudor <laurentiu.tudor@nxp.com>,
        "stuyoder@gmail.com" <stuyoder@gmail.com>
To: Razvan Stefanescu <razvan.stefanescu@nxp.com>,
        Bogdan Purcareata <bogdan.purcareata@nxp.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM3PR04MB0743F62497ED0CB445F51524E67E0@AM3PR04MB0743.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On September 29, 2017 6:59:18 AM PDT, Razvan Stefanescu <razvan=2Estefanesc=
u@nxp=2Ecom> wrote:
>
>
>> -----Original Message-----
>> From: Bogdan Purcareata
>> Sent: Friday, September 29, 2017 16:36
>> To: Razvan Stefanescu <razvan=2Estefanescu@nxp=2Ecom>;
>> gregkh@linuxfoundation=2Eorg
>> Cc: devel@driverdev=2Eosuosl=2Eorg; linux-kernel@vger=2Ekernel=2Eorg;
>> netdev@vger=2Ekernel=2Eorg; agraf@suse=2Ede; arnd@arndb=2Ede; Alexandru
>Marginean
>> <alexandru=2Emarginean@nxp=2Ecom>; Ruxandra Ioana Radulescu
>> <ruxandra=2Eradulescu@nxp=2Ecom>; Laurentiu Tudor
><laurentiu=2Etudor@nxp=2Ecom>;
>> stuyoder@gmail=2Ecom
>> Subject: RE: [RESEND PATCH 2/6] staging: fsl-dpaa2/ethsw: Add
>Freescale DPAA2
>> Ethernet Switch driver
>>=20
>> > Introduce the DPAA2 Ethernet Switch driver, which manages Datapath
>Switch
>> > (DPSW) objects discovered on the MC bus=2E
>> >
>> > Suggested-by: Alexandru Marginean <alexandru=2Emarginean@nxp=2Ecom>
>> > Signed-off-by: Razvan Stefanescu <razvan=2Estefanescu@nxp=2Ecom>

This looks pretty good for a new switchdev driver, is there a reason you c=
an't target drivers/net/ethernet instead of staging? Is it because the MC b=
us code is still in staging (AFAICT)?

--=20
Florian
