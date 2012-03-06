From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [PATCH v3 1/2] powerpc/44x: Add new compatible value for EMAC
 node of APM821XX dts file.
Date: Tue, 6 Mar 2012 17:15:30 -0500
Message-ID: <CA+5PVA56KhuBjbszR8_k_OAyQc=1fHxbMXE4ZFO9ahANVJi_Ww@mail.gmail.com>
References: <1330920224-3006-1-git-send-email-dhdang@apm.com>
	<1330945062-15760-1-git-send-email-dhdang@apm.com>
	<20120306.170819.2135873666210523674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dhdang@apm.com, benh@kernel.crashing.org, paulus@samba.org,
	sr@denx.de, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120306.170819.2135873666210523674.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 6, 2012 at 5:08 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Duc Dang <dhdang@apm.com>
> Date: Mon, =A05 Mar 2012 17:57:42 +0700
>
>> This compatible value will be used to distinguish some special featu=
res of APM821XX EMAC: no half duplex mode support, configuring jumbo fr=
ame.
>>
>> Signed-off-by: Duc Dang <dhdang@apm.com>
>
> Applied.

So I guess we're taking these through your tree?  I guess that works ou=
t
well enough since the other patches I was going to send to Ben aren't
panning out anyway.

josh
