From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Tue, 20 Mar 2012 10:42:03 -0700
Message-ID: <4F68C16B.1090707@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org> <4F61F551.5010608@gmail.com> <4F639851.5080500@gmail.com> <4F674616.8080103@gmail.com> <CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com> <4F674FF5.2060406@gmail.com> <4F6751B2.1030809@openwrt.org> <4F681B78.9000207@gmail.com> <CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com> <4F68235C.5090701@gmail.com> <CAD2nsn0toAjyWw48J7oREES0=x6D72hMntP+WpAjHmR5drd-tQ@mail.gmail.com> <4F682555.3020502@gmail.com> <20328.16366.166909.255035@gargle.gargle.HOWL> <4F6891F1.9010105@gmail.com> <20328.41155.468698.30887@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless@gmail.com>,
	Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20328.41155.468698.30887@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2012 08:22 AM, Sujith Manoharan wrote:
> Justin P. Mattock wrote:
>> both mohammed and sujith Thank you for the patches for this issue!
>> I really appreciate this..
>>
>> I went and applied the debug printk and added ath_node_attach as well to
>> my linux-next clone, will run for a few days to see if I get anything..
>> full dmesg is here..: http://fpaste.org/jHSX/
>
> Thanks for testing and please report if the issue is fixed.
>
> Sujith
>

no worries.. hopefully we can get this bug fixed.. will continue running 
these patches and will send out anything I see..

Justin P. Mattock
