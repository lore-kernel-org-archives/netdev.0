From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Tue, 30 Aug 2016 09:06:30 -0700
Message-ID: <CALCETrWw6fTTugSFcBhW=fv09GrSXQ+vZxuG0ewb+cod8nq4MQ@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> Hi,
>
> This series is a proof of concept to fill some missing part of seccomp as=
 the
> ability to check syscall argument pointers or creating more dynamic secur=
ity
> policies. The goal of this new stackable Linux Security Module (LSM) call=
ed
> Landlock is to allow any process, including unprivileged ones, to create
> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or the
> OpenBSD Pledge. This kind of sandbox help to mitigate the security impact=
 of
> bugs or unexpected/malicious behaviors in userland applications.

Micka=C3=ABl, will you be at KS and/or LPC?
