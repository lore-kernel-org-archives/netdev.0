From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: SR-IOV problem with Intel 82599EB (not enough MMIO resources for SR-IOV)
Date: Tue, 13 Nov 2012 10:29:28 -0800
Message-ID: <CAE9FiQXTCjpSbAi_DAhQomDo3F1MBECUK48eMnUsyso3a_sayQ@mail.gmail.com>
References: <201211081915083774239@gmail.com>
	<509B962C.6070002@gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A072D565E76@ORSMSX106.amr.corp.intel.com>
	<CANmqhJDJXcbUxyt6YD6ktxZCDJ=VqiwhGXP+fLMukQr0o-XwxQ@mail.gmail.com>
	<CAErSpo4xn9t=4yXGLdPQMtUJF=n38tYrMutAoj7NCsLUzQEbcg@mail.gmail.com>
	<CANmqhJAjwP8CLEKpgsDbT-7+n=hf30LbYrTAu+qDH09LzETD4g@mail.gmail.com>
	<A3A921390EAE4044940E99EBF13D97321AE21E15@FMSMSX104.amr.corp.intel.com>
	<CAE9FiQXnP2gpy9z6VNGSpimLkhDYKp6Qr=9nGZ9d-pKdohA4bw@mail.gmail.com>
	<A3A921390EAE4044940E99EBF13D97321AE21FBB@FMSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jason Gao <pkill.2012@gmail.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"ddutile@redhat.com" <ddutile@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Li, Sibai" <sibai.li@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <A3A921390EAE4044940E99EBF13D97321AE21FBB@FMSMSX104.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2012 at 10:25 AM, Li, Sibai <sibai.li@intel.com> wrote:
>
> Never append "pci=realloc" for both kernel 2.6.32.279 and kernel 3.5.0 above.

well,  can you both post boot log with "debug ignore_loglevel" ?
