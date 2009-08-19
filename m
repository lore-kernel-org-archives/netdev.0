From: Avi Kivity <avi@redhat.com>
Subject: Re: configfs/sysfs
Date: Wed, 19 Aug 2009 23:53:37 +0300
Message-ID: <4A8C6651.4000206@redhat.com>
References: <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com> <1250706227.27590.156.camel@haakon2.linux-iscsi.org> <4A8C5CBB.10605@redhat.com> <20090819204821.GA27292@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	Joel Becker <joel.becker@oracle.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090819204821.GA27292@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/2009 11:48 PM, Ingo Molnar wrote:
>
> FYI, an example of such a syscall design and
> implementation has been merged upstream in the .31 merge
> window, see:
>
> <big snip>
>
>    

Exactly.  It's beautiful.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

