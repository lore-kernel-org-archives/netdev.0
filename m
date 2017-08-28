From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH net-next v7 00/10] Landlock LSM: Toward
 unprivileged sandboxing
Date: Mon, 28 Aug 2017 13:38:26 +1000 (AEST)
Message-ID: <alpine.LRH.2.20.1708281335290.8842@namei.org>
References: <20170821000933.13024-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="1665246916-700125660-1503891508=:8842"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
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
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
To: =?ISO-8859-15?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-9571-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1665246916-700125660-1503891508=:8842
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Mon, 21 Aug 2017, Mickaël Salaün wrote:

> ## Why a new LSM? Are SELinux, AppArmor, Smack and Tomoyo not good enough?
> 
> The current access control LSMs are fine for their purpose which is to give the
> *root* the ability to enforce a security policy for the *system*. What is
> missing is a way to enforce a security policy for any application by its
> developer and *unprivileged user* as seccomp can do for raw syscall filtering.
> 

You could mention here that the first case is Mandatory Access Control, 
in general terms.



-- 
James Morris
<jmorris@namei.org>

--1665246916-700125660-1503891508=:8842--
