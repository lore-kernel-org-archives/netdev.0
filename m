From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Tue, 01 May 2012 10:47:31 +1000
Message-ID: <1335833251.20866.96.camel@pasglop>
References: <1335760199.20866.33.camel@pasglop>
	 <4F9E188E.80503@googlemail.com> <1335763568.20866.37.camel@pasglop>
	 <20120430.134140.1738751315208907289.davem@davemloft.net>
	 <1335822926.20866.47.camel@pasglop> <1335823049.20866.48.camel@pasglop>
	 <4F9F12ED.1090009@googlemail.com> <1335831987.20866.93.camel@pasglop>
	 <4F9F31E0.5020308@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9F31E0.5020308@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-01 at 02:44 +0200, Jan Seiffert wrote:
> But a sane way forward?
> 
> BTW, has anyone checked the new syscall filter code for these ...
> misfortunes?
> I mean before the ABI is set in stone...
> 
Nope, not yet, looks like something I should do :-)

Cheers,
Ben.
