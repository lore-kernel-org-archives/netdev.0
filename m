From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 0/6] VSOCK for Linux upstreaming
Date: Sun, 11 Nov 2012 16:59:13 -0500
Message-ID: <50A01FB1.1080502@gmail.com>
References: <854640502.31217031.1352140335740.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: George Zhang <georgezhang@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <854640502.31217031.1352140335740.JavaMail.root@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 11/05/2012 01:32 PM, George Zhang wrote:
> Sasha,
> There is a 'brief' implementation notes aboutVSOCK protocol family
> in af_vsock.c. More about user space layer socket programming is from
> VMCI Socket Programming Guide. (remove crosstalk@vmware.com for email bouncing).
> thanks,
> George

So all the documentation I see in the VMCI Socket Programming Guide is about
userspace programming, and the documentation in af_vsock.c is all around
implementation considerations.

Is there anything that documents the actual protocol? Just for example, whats
the deal with REQUEST/REQUEST2? it appears like something to deal with legacy
code, but I'd really like to have it documented somewhere instead of trying
to figure how everything works by looking at the code.


Thanks,
Sasha
