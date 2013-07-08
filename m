From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [GIT] Networking
Date: Mon, 08 Jul 2013 09:38:29 +0300
Message-ID: <51DA5E65.5060006@linux.intel.com>
References: <20130707.132133.1335860703202153192.davem@davemloft.net> <CA+55aFzgBXwye=ebPmEDN_6yqdKA6ZaD9hSUzbFjSacC_v3y5g@mail.gmail.com> <CA+55aFyvZAQbaEyq5atQbTjHTz_hodzhWKX_7SRL8nq+yBA14A@mail.gmail.com> <20130707.201449.1176672898198722699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130707.201449.1176672898198722699.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/07/2013 06:14, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sun, 7 Jul 2013 15:33:31 -0700
>
>> End result: I think the code is salvageable and people who want this
>> kind of busy-looping can have it. But I really don't want to merge it
>> as-is. I think it was badly done, I think it was badly documented, and
>> I think somebody over-sold the feature by emphasizing the upsides and
>> not the problems.
>
> Fair enough, Eliezer, please address all of Linus's feedback.
>
> It's holding the entire net-next merge up.
>

OK
