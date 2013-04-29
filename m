From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next 3/3] ARM: net: bpf_jit_32: support BPF_S_ANC_SECCOMP_LD_W
 instruction
Date: Mon, 29 Apr 2013 12:16:31 +0200
Message-ID: <517E487F.2050700@redhat.com>
References: <1367029047-14830-1-git-send-email-xi.wang@gmail.com> <1367029047-14830-4-git-send-email-xi.wang@gmail.com> <517B6FC5.7070003@redhat.com> <CAKU6vyathpp4Ky_kcTu_WFenLEdo9Mai4TUE=EWYo9=UuQUMcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKU6vyathpp4Ky_kcTu_WFenLEdo9Mai4TUE=EWYo9=UuQUMcg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/27/2013 08:32 PM, Xi Wang wrote:
> On Sat, Apr 27, 2013 at 2:27 AM, Daniel Borkmann <dborkman@redhat.com> wrote:

>> Besides all that, I think I also pointed you to a patch that already made
>> it in for ARM, not sure why you keep posting the ARM JIT implementation?
>
> That's why I asked in the other post if you wanted me to rebase
> against linux-next or net-next.  The ARM part 3/3 is not needed if
> rebased against linux-next with Nicolas's patches.

This discussion was only in terms of the unified interface, not the seccomp
JIT itself. If you speak about ``patch'' (and not ``patch set'') I assumed
you were only referring to the first one.
