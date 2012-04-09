From: Markus Gutschke <markus@chromium.org>
Subject: Re: [PATCH v17 15/15] Documentation: prctl/seccomp_filter
Date: Mon, 9 Apr 2012 13:47:30 -0700
Message-ID: <CAE6n16kMv5Y+Cp9XZ=tmK0sgoJJZ6CJUq_ttuNEUMb4JFXJ33g@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-16-git-send-email-wad@chromium.org> <20120406142644.223ffff0.akpm@linux-foundation.org>
 <CABqD9haT5h-7LMkbGSaQbnk8SJj9L21GT61UZCMVWLJCTw9OBg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	hpa@zytor.com, mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1228-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: markus@google.com
In-Reply-To: <CABqD9haT5h-7LMkbGSaQbnk8SJj9L21GT61UZCMVWLJCTw9OBg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

No matter what you do, please leave the samples accessible somewhere.
They proved incredibly useful in figuring out how the API works. I am
sure, other developers are going to appreciate them as well.

Alternatively, if you don't want to include the samples with the
kernel sources, figure out how you can include a sample in the
official manual page for prctl().


Markus
