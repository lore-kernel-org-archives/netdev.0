From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: networking bugs and bugme.osdl.org
Date: 28 Jun 2003 20:19:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056827972.6295.28.camel@dhcp22.swansea.linux.org.uk>
References: <3EFCC1EB.2070904@candelatech.com>
	 <20030627.151906.102571486.davem@redhat.com>
	 <1056755336.5459.16.camel@dhcp22.swansea.linux.org.uk>
	 <20030627.172123.78713883.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, davidel@xmailserver.org, mbligh@aracnet.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030627.172123.78713883.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sad, 2003-06-28 at 01:21, David S. Miller wrote:
>    From: Alan Cox <alan@lxorguk.ukuu.org.uk>
>    Date: 28 Jun 2003 00:08:56 +0100
> 
>    Tried doing an SQL query or text analysis for similarities on random
>    messages lurking in private mailboxes
> 
> I respond to private reports with "please send this to the lists,
> what if I were on vacation for the next month?"  I never actually
> process or analyze such reports.

Which means you miss stuff. Here is an example my tools found yesterday

18 months ago someone with a specific printer reported doing network printing
to it crashed the kernel. Lost in the noise, filed in bugzilla, categorised 
mentally at the time as "weird".

Not long ago a second identical report popped up. Different setup, same
network printing, similar "it reboots" report.

So now I've gone chasing tcpdumps from these.

Its a *different* thing to the kind of patch management you are doing, but its
only possible because of tools like bugzilla
