From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Mon, 24 Apr 2017 17:53:26 +0200
Message-ID: <8a035544-f9c3-e384-8a18-a78e42b10402@suse.cz>
References: <f7a94f4e-6d93-a447-a62f-3f290e66c647@suse.cz>
 <20170424.110844.1321374394090353753.davem@davemloft.net>
 <614ca52b-8a43-244e-8a3a-c39145ecc3e8@suse.cz>
 <20170424.115118.1652158849030310645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, mingo@redhat.com, tglx@linutronix.de,
        hpa@zytor.com, x86@kernel.org, jpoimboe@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170424.115118.1652158849030310645.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24/2017, 05:51 PM, David Miller wrote:
> I said I'm not OK with the alignment

So in short, the suggested macros add no alignment.

-- 
js
suse labs
