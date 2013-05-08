From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: add device IDs for Dell 5804
 (Novatel E371) WWAN card
Date: Wed, 08 May 2013 12:19:22 -0700 (PDT)
Message-ID: <20130508.121922.553557463648781118.davem@davemloft.net>
References: <87li7r6bx1.fsf@nemi.mork.no>
	<20130508.120850.755474428060131481.davem@davemloft.net>
	<CAO2Qn5myQRhscszx0WRX588EP5NzPZuOsr1mrH3p4yDna8YP-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, dcbw@redhat.com, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: dagofthedofg@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAO2Qn5myQRhscszx0WRX588EP5NzPZuOsr1mrH3p4yDna8YP-w@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: dag dg <dagofthedofg@gmail.com>
Date: Wed, 8 May 2013 14:11:48 -0500

> Just a side note on this. By default for this device, modprobe won't
> load and assign the option driver. However, if cdc_ether is
> blacklisted and you try to load option onto the device, it will try t=
o
> load the option driver onto where cdc_ether was being used, which wil=
l
> cause the system to lock up. I'm not sure what needs to be done to
> force qmi_wwan to take over cdc_ether without option grabbing these
> IDs...

I'm sure that Bj=F8rn can answer this question.
