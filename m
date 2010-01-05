From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: RE: [PATCH] drivers/net/stmmac/gmac.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 10:26:38 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090208923F@mi8nycmail19.Mi8.com>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F674@mi8nycmail19.Mi8.com> <4B42F226.6010207@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og102.obsmtp.com ([64.18.1.183]:43359 "HELO
	exprod6og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754339Ab0AEP0m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 10:26:42 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B42F226.6010207@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, January 05, 2010 1:03 AM, Giuseppe CAVALLARO wrote:
> Hi Hartley,

Hello.

> H Hartley Sweeten wrote:
>> Use the %pM kernel extension to display the MAC address.
>
> Thanks for this patch.
> As discussed in the mailing list, I'm reworking some patches for the
> stmmac driver (fixing compilation errors and trying to make the code
> more generic).
> I've already modified the gmac.c file now splitted in new two files.
> So I'm wondering if it's worth applying this patch into the new code,
> directly.

Feel free to apply this with your new code.

I am resubmitting a number of the %pM patches to David and will drop
this one for now.  If you don't get a chance to submit the updated
gmac.c soon please let me know and I will repost this patch.

Thanks,
Hartley
