From: George Zhang <georgezhang@vmware.com>
Subject: Re: [PATCH 0/6] VSOCK for Linux upstreaming
Date: Mon, 5 Nov 2012 10:32:15 -0800 (PST)
Message-ID: <854640502.31217031.1352140335740.JavaMail.root@vmware.com>
References: <CA+1xoqcMo1RrJKAaS+k5cVuRonRF+go7tJKUkARP_xcuZAwoGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CA+1xoqcMo1RrJKAaS+k5cVuRonRF+go7tJKUkARP_xcuZAwoGw@mail.gmail.com>
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

Sasha,
There is a 'brief' implementation notes aboutVSOCK protocol family
in af_vsock.c. More about user space layer socket programming is from
VMCI Socket Programming Guide. (remove crosstalk@vmware.com for email bouncing).
thanks,
George

----- Original Message -----
From: "Sasha Levin" <levinsasha928@gmail.com>
To: "George Zhang" <georgezhang@vmware.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, pv-drivers@vmware.com, vm-crosstalk@vmware.com, davem@davemloft.net, gregkh@linuxfoundation.org
Sent: Monday, November 5, 2012 10:23:02 AM
Subject: Re: [PATCH 0/6] VSOCK for Linux upstreaming

Hi George,

On Mon, Nov 5, 2012 at 1:00 PM, George Zhang <georgezhang@vmware.com> wrote:
> For additional information about the use of VMCI and in particular
> VMCI Sockets, please refer to the VMCI Socket Programming Guide
> available at https://www.vmware.com/support/developer/vmci-sdk/.

Is there documentation about the protocol itself? I couldn't find it
on the link above.


Thanks,
Sasha
