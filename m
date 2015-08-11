From: yalin wang <yalin.wang2010@gmail.com>
Subject: Re: [PATCH] isdn:remove reverse_bits(), use revbit8()
Date: Tue, 11 Aug 2015 09:38:23 +0800
Message-ID: <D170D6B8-1B24-4F7E-8A20-4CBD3D0BFB8A@gmail.com>
References: <48EEE6BC-BAFE-4545-A860-237FBD1E279B@gmail.com> <20150810.143012.1342124147857318471.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150810.143012.1342124147857318471.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Aug 11, 2015, at 05:30, David Miller <davem@davemloft.net> wrote:
> 
> From: yalin wang <yalin.wang2010@gmail.com>
> Date: Mon, 10 Aug 2015 17:15:57 +0800
> 
>> This change isdn driver, remove reverse_bits() function,
>> use the generic revbit8() function instead.
>> 
>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> 
> Applied, however please format your Subject lines better in the
> future.
> 
> There should be a space after the subsystem specifier and the ':'
> character.  So "isdn: "
> 
> Then you should capitalize the description in the Subject line
> because it is very much like an English sentence.
i see,
Thanks for your kindly remind !
