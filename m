From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: networking bugs and bugme.osdl.org
Date: 28 Jun 2003 20:20:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056828052.6295.31.camel@dhcp22.swansea.linux.org.uk>
References: <3EFCC1EB.2070904@candelatech.com>
	 <20030627.151906.102571486.davem@redhat.com>
	 <3EFCC6EE.3020106@candelatech.com>
	 <20030627.170022.74744550.davem@redhat.com>
	 <20030628001954.GD18676@work.bitmover.com>
	 <34700000.1056760028@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Larry McVoy <lm@bitmover.com>, "David S. Miller" <davem@redhat.com>,
   greearb@candelatech.com, davidel@xmailserver.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Martin J. Bligh" <mbligh@aracnet.com>
In-Reply-To: <34700000.1056760028@[10.10.2.4]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sad, 2003-06-28 at 01:27, Martin J. Bligh wrote:
> That's a trivial change to make if you want it. we just add a "reviewed"
> / "certified" state between "new" and "assigned". Yes, might be a good 
> idea.  I'm not actually that convinced that "assigned" is overly useful
> in the context of open-source, but that's a separate discussion.

Most bugzilla's seem to use VERIFIED for this, and it means people who
have better things to do can just pull bugs that are verified and/or
tagged with "patch" in the attachments
