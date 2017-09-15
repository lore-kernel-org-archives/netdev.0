From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [PATCH 0/3] Fix y2038 issues for security/keys subsystem
Date: Fri, 15 Sep 2017 16:38:35 +0800
Message-ID: <CAMz4kuLKrwR3M=RX+SOX0k=MxxD9YMJF9YpGDpwZuC=M4zR_kw@mail.gmail.com>
References: <cover.1502246501.git.baolin.wang@linaro.org> <4455.1502267323@warthog.procyon.org.uk>
 <CAMz4kuL-mriUk3YV6Mz9xgC7geNe5a05vhjfXaxt58x=7BUo0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        James Morris <james.l.morris@oracle.com>,
        "Serge E. Hallyn" <serge@hallyn.com>, marc.dionne@auristor.com,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>,
        keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAMz4kuL-mriUk3YV6Mz9xgC7geNe5a05vhjfXaxt58x=7BUo0w@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

On 21 August 2017 at 20:12, Baolin Wang <baolin.wang@linaro.org> wrote:
> Hi David and James,
>
> On 9 August 2017 at 16:28, David Howells <dhowells@redhat.com> wrote:
>> The rxrpc patch isn't part of the security/keys subsystem.  I'll push it
>> to the network tree.  The other two I'll push to James.
>
> Could you apply this patch serials if there are no other comments? Thanks.

Could you apply patch1 and patch2? I have seen patch3 was merged into
4.14 by David. Thanks.

-- 
Baolin.wang
Best Regards
