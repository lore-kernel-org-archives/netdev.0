From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Thu, 12 May 2005 09:33:00 -0700
Message-ID: <4283853C.9070608@hp.com>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>	<1115743966.8570.26.camel@rh4>	<20050511080446.fnstrvtzq8gk8884@158.49.151.11>	<1115825081.8570.93.camel@rh4> <20050512112827.7danjtr4kckg8swc@158.49.151.11>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manuel Perez Ayala <mperaya@alcazaba.unex.es>
In-Reply-To: <20050512112827.7danjtr4kckg8swc@158.49.151.11>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since both read and write boundaries are being changed, doesn't netperf need to 
be run in each direction?

rick jones
