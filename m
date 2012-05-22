From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: tcp timestamp issues with google servers
Date: Tue, 22 May 2012 09:38:19 -0700
Message-ID: <CAGK4HS9cGnOcoLAL1pggWvMG1B40rWyqc3BHsddUvnii4EvTcQ@mail.gmail.com>
References: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
	<1337278363.3403.39.camel@edumazet-glaptop>
	<87zk90s0em.fsf@tucsk.pomaz.szeredi.hu>
	<1337701259.3361.208.camel@edumazet-glaptop>
	<87mx50rz34.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mx50rz34.fsf@tucsk.pomaz.szeredi.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Okay. =A0Is there a way to find out whether there is a middlebox or n=
ot?
>

Miklos,
Maybe tcptraceroute[1] can help you figure this out.

Hope this helps.
Vijay

[1] http://michael.toren.net/code/tcptraceroute/
