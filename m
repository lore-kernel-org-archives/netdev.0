From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Tue, 03 Dec 2002 19:52:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DED51E9.1080408@pobox.com>
References: <3DE33D6D.25B9C9B4@isg.de> <20021126.021546.91313706.davem@redhat.com> <3DED2EA9.D812C881@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DED2EA9.D812C881@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pardon my dumb question, but what parts of RFC2863 require kernel 
additions over and above your link state patch?

Your second patch I am less enthusiastic about than the first... :(

I wonder if userspace cannot figure out ifOperStatus from existing data 
we make available?

	Jeff
