From: "Peter W. Morreale" <pmorreale@novell.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 06:59:19 -0600
Message-ID: <1237467559.6926.31.camel@hermosa>
References: <49C12E64.1000301@us.ibm.com> <87prge1rhu.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Vernon Mauery <vernux@us.ibm.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <87prge1rhu.fsf@basil.nowhere.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-03-18 at 21:54 +0100, Andi Kleen wrote:
> Vernon Mauery <vernux@us.ibm.com> writes:
> >

> 
> But then again I'm not sure it's  worth it if the problem only
> happens in out of tree RT.
> 

Heh.  That darn bastard child again, eh?  :-)


Recall that adaptive spin,developed in RT, is now in mainline. 

Best,
-PWM


