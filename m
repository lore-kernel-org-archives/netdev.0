From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [RFC PATCH net-next 0/6] seccomp filter JIT
Date: Fri, 26 Apr 2013 08:15:39 -0400
Message-ID: <CAKU6vyZ1QYTtwNahEb=aeTqym660-XBF20CYqVb8RXgsX93MeQ@mail.gmail.com>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
 <20130426112539.GA3736@osiris> <20130426114622.GB3736@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130426114622.GB3736@osiris>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 26, 2013 at 7:46 AM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
> And build fine on s390.

Thanks!

>> Btw. are there any test cases around for BPF JIT?
>> Not only for the new seccomp but also netfilter?
>
> This however is still a valid question.

Not sure about test cases for BPF JIT in general.  I used the examples
under "samples/seccomp/" for testing; they are seccomp filters though.

- xi
