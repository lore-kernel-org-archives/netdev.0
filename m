From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH net-next v7 02/10] bpf: Add eBPF program subtype and
 is_valid_subtype() verifier
Date: Mon, 28 Aug 2017 13:46:37 +1000 (AEST)
Message-ID: <alpine.LRH.2.20.1708281345280.8842@namei.org>
References: <20170821000933.13024-1-mic@digikod.net> <20170821000933.13024-3-mic@digikod.net> <20170823024452.zvizovwfd7xjucsx@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-9572-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170823024452.zvizovwfd7xjucsx@ast-mbp>
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2017, Alexei Starovoitov wrote:

> more general question: what is the status of security/ bits?
> I'm assuming they still need to be reviewed and explicitly acked by James, right?

Yep, along with other core security developers where possible.


-- 
James Morris
<jmorris@namei.org>
