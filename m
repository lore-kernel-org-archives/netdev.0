From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp timestamp issues with google servers
Date: Tue, 22 May 2012 17:40:59 +0200
Message-ID: <1337701259.3361.208.camel@edumazet-glaptop>
References: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
	 <1337278363.3403.39.camel@edumazet-glaptop>
	 <87zk90s0em.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zk90s0em.fsf@tucsk.pomaz.szeredi.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-22 at 17:25 +0200, Miklos Szeredi wrote:

> So it appears.  The IP address is certainly registered to Google.

Good, but you could have a middlebox doing transparent proxying.

The SYNACK could be send by this box.
